#ifndef SRC_STATS_H_
#define SRC_STATS_H_

#include <sys/time.h>

#include "config.h"
#include "redismodule.h"
#include "util/dict.h"

struct RedisAI_RunStats {
  RedisModuleString* key;
  RAI_RunType type;
  RAI_Backend backend;
  char* devicestr;
  char* tag;
  long long duration_us;
  long long samples;
  long long calls;
  long long nerrors;
};

AI_dict* run_stats;

long long ustime(void);
mstime_t mstime(void);

void* RAI_AddStatsEntry(RedisModuleCtx* ctx, RedisModuleString* key,
                        RAI_RunType type, RAI_Backend backend,
                        const char* devicestr, const char* tag);

void RAI_RemoveStatsEntry(void* infokey);

void RAI_ListStatsEntries(RAI_RunType type, long long* nkeys,
                          RedisModuleString*** keys, const char*** tags);

/**
 *
 * @param rstats
 * @return 0 on success, or 1 if the reset failed
 */
int RAI_ResetRunStats(struct RedisAI_RunStats *rstats);

/**
 * Safely add datapoint to the run stats. Protected against null pointer runstats
 * @param rstats
 * @param duration
 * @param calls
 * @param errors
 * @param samples
 * @return 0 on success, or 1 if the addition failed
 */
int RAI_SafeAddDataPoint(struct RedisAI_RunStats* rstats,  long long duration, long long calls, long long errors, long long samples );

void RAI_FreeRunStats(struct RedisAI_RunStats* rstats);


/**
 *
 * @param runkey
 * @param rstats
 * @return 0 on success, or 1 if the the run stats with runkey does not exist
 */
int RAI_GetRunStats(const char *runkey,struct RedisAI_RunStats **rstats);

void RedisAI_FreeRunStats(RedisModuleCtx* ctx, struct RedisAI_RunStats* rstats);

#endif /* SRC_SATTS_H_ */
