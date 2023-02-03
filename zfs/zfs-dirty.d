#!/usr/sbin/dtrace -s

# displays the amount of data synced from dirty data memory to the pool and how much it took to sync it (write it to the pool)
# run it with the pool name as the first argument, e.g. ./zfs-dirty.d mypool
# example output
# CPU     ID                    FUNCTION:NAME
#   2  82272                  none:txg-synced 7464MB of 9804MB synced in 32.64 seconds

txg-syncing
/((dsl_pool_t *)arg0)->dp_spa->spa_name == $$1/
{
        start = timestamp;
        this->dp = (dsl_pool_t *) arg0;
        d_total = this->dp->dp_dirty_total;
        d_max = `zfs_dirty_data_max`;
}

txg-synced
/start && ((dsl_pool_t *)arg0)->dp_spa->spa_name == $$1/
{
        this->d = timestamp - start;
        printf("%4dMB of %4dMB synced in %d.%02d seconds",
                d_total / 1024 / 1024,
                d_max / 1024 / 1024,
                this->d / 1000000000,
                (this->d / 1000000) % 100);
}
