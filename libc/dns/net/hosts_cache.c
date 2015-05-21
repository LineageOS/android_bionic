/*
 * Fast lookup cache for /etc/hosts files
 *
 */
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/file.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <strings.h>
#include <utime.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#ifdef _HOSTS_CACHE_TEST
	#define HOSTS_FILE "hosts"
	#define HOSTS_CACHE_FILE "hosts.cache"
#else
	#define HOSTS_FILE "/system/etc/hosts"
	/* This is a location that netd (which actually calls this) has
	 * SELinux permissions to write to:
	 */
	#define HOSTS_CACHE_FILE "/data/misc/net/hosts.cache"
#endif

struct _hosts_entry {
	char ip[40];
	char hostname[255];
};

static int _hosts_cmp(const void *a, const void *b) {
	return strncasecmp(((struct _hosts_entry *)a)->hostname,
		((struct _hosts_entry *)b)->hostname,
		sizeof(((struct _hosts_entry *)a)->hostname));
}

/* Taken from bionic */
static int get_canonname(const struct addrinfo *pai, struct addrinfo *ai,
		const char *str) {
	if ((pai->ai_flags & AI_CANONNAME) != 0) {
		ai->ai_canonname = strdup(str);
		if (ai->ai_canonname == NULL)
			return EAI_MEMORY;
	}
	return 0;
}

static int _create_hosts_cache() {
	FILE *hostsf, *cachef;
	char buf[8*1024];
	char *p, *ip, *host, *comment;
	struct stat cache_stat;
	struct stat hosts_stat;

	// Open cache file and hosts file and check if cache is up to date
	if ((hostsf = fopen(HOSTS_FILE, "r")) == NULL) {
		return 1;
	}
	if (fstat(fileno(hostsf), &hosts_stat) < 0) {
		fclose(hostsf);
		return 1;
	}
	if (stat(HOSTS_CACHE_FILE, &cache_stat) == 0 &&
			cache_stat.st_mtime == hosts_stat.st_mtime) {
		fclose(hostsf);
		return 0;
	}
	if (hosts_stat.st_size < 1024 * 100) {
		fclose(hostsf);
		return 1;
	}
	if (flock(fileno(hostsf), LOCK_EX) < 0) {
		fclose(hostsf);
		return 1;
	}
	if (stat(HOSTS_CACHE_FILE, &cache_stat) == 0 &&
			cache_stat.st_mtime == hosts_stat.st_mtime) {
		fclose(hostsf);
		return 0;
	}
	if ((cachef = fopen(HOSTS_CACHE_FILE, "w")) == NULL) {
		fclose(hostsf);
		return 1;
	}
	fchmod(fileno(cachef), 00644);

	// Create list of host file entries
	unsigned int hosts_list_N = 1024;
	unsigned int hosts_list_n = 0;
	struct _hosts_entry *hosts_list =
		malloc(sizeof(struct _hosts_entry) * 1024);
	if (!hosts_list) {
		fclose(hostsf);
		fclose(cachef);
		return 1;
	}

	while (!feof(hostsf)) {
		if ((p = fgets(buf, sizeof buf, hostsf)) == NULL)
			break;

		comment = strpbrk(p, "\n#");
		if (comment != NULL) {
			*comment = '\0';
		}

		for (; *p == ' ' || *p == '\t'; p++);
		ip = p;
		for (; *p != '\0' && *p != ' ' && *p != '\t'; p++);
		if (*p == '\0')
			continue;
		*p = 0;
		p++;
		while (*p != '\0') {
			for (; *p == ' ' || *p == '\t'; p++);
			host = p;
			for (; *p != '\0' && *p != ' ' && *p != '\t'; p++);
			if (*p != '\0') {
				*p = '\0';
				p++;
			}

			if (hosts_list_n >= hosts_list_N) {
				hosts_list_N += 10000;
				hosts_list = realloc(hosts_list,
						sizeof(struct _hosts_entry) * hosts_list_N);
				if (!hosts_list) {
					fclose(hostsf);
					fclose(cachef);
					return 1;
				}
			}
			memset(&hosts_list[hosts_list_n], 0, sizeof(struct _hosts_entry));
			strncpy(hosts_list[hosts_list_n].ip, ip, sizeof(hosts_list->ip));
			strncpy(hosts_list[hosts_list_n].hostname, host,
					sizeof(hosts_list->hostname));
			hosts_list_n++;
		}
	}

	// Sort the hosts list
	qsort(hosts_list, hosts_list_n, sizeof(struct _hosts_entry), _hosts_cmp);

	// Write cache file
	if (fwrite(hosts_list, sizeof(struct _hosts_entry), hosts_list_n, cachef)
			== hosts_list_n) {
		// Set cache file mtime to hosts file mtime
		struct timespec times[2] = { { hosts_stat.st_mtime, 0 },
			{ hosts_stat.st_mtime, 0 } };
		fflush(cachef);
		futimens(fileno(cachef), times);
	}
	fclose(cachef);

	// Cleanup
	free(hosts_list);
	fclose(hostsf);

	return 2;
}

/**
 * _cached_hosts_lookup: Lookup name using hints pai, store result(s) pointer
 * into retval, and return
 *  1 -> cache failure, continue with default hosts file handler
 *  0 -> cache success, but retval might still not contain a result
 *       (it is set to NULL though)
 */
int _cached_hosts_lookup(const char *name, const struct addrinfo *pai,
		struct addrinfo **retval) {
	if (_create_hosts_cache() == 1)
		return 1;

	FILE *cachef = fopen(HOSTS_CACHE_FILE, "r");
	flock(fileno(cachef), LOCK_SH);
	struct stat cache_stat;
	fstat(fileno(cachef), &cache_stat);
	unsigned int nrecords = cache_stat.st_size / sizeof(struct _hosts_entry);

	unsigned int min = 0, max = nrecords;
	struct _hosts_entry host;
	int found = -1;
	while (min < max) {
		unsigned int pivot = (max + min) / 2;
		fseek(cachef, pivot * sizeof(struct _hosts_entry), SEEK_SET);
		fread(&host, sizeof(struct _hosts_entry), 1, cachef);

		int cmp = strcasecmp(host.hostname, name);
		//printf("cmp %d (min=%d max=%d) %s\n", pivot, min, max, host.hostname);
		if (cmp > 0)
			max = pivot;
		else if (cmp < 0) {
			if (min == pivot) break;
			min = pivot;
		}
		else {
			found = pivot;
			break;
		}
	}

	*retval = NULL;
	if (found >= 0) {
		while (found > 0) {
			fseek(cachef, (found - 1) * sizeof(struct _hosts_entry), SEEK_SET);
			fread(&host, sizeof(struct _hosts_entry), 1, cachef);
			if (strcasecmp(host.hostname, name) == 0) {
				found--;
			}
			else break;
		}

		for (;; found++) {
			fseek(cachef, found * sizeof(struct _hosts_entry), SEEK_SET);
			if (fread(&host, sizeof(struct _hosts_entry), 1, cachef) < 1)
				break;
			if (strcasecmp(host.hostname, name) != 0)
				break;

			int error;
			struct addrinfo hints, *res0, *res;
			hints = *pai;
			hints.ai_flags = AI_NUMERICHOST;
			error = getaddrinfo(host.ip, NULL, &hints, &res0);
			if (error)
				continue;
			for (res = res0; res; res = res->ai_next) {
				res->ai_flags = pai->ai_flags;

				if (pai->ai_flags & AI_CANONNAME) {
					if (get_canonname(pai, res, host.hostname) != 0) {
						freeaddrinfo(res0);
						continue;
					}
				}
			}
			*retval = res0;
			retval = &(res0->ai_next);
		}
	}

	fclose(cachef);
	return 0;
}
