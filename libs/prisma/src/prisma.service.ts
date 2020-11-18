import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import Knex from 'knex';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
    public $queryBuilder: Knex;

    constructor() {
        super({
            errorFormat: 'minimal',
            log: [
                // 'query',
                'info',
                'warn',
                'error',
            ],
        });
    }

    async onModuleInit() {
        await this.$connect();
        // eslint-disable-next-line @typescript-eslint/no-var-requires
        this.$queryBuilder = require('knex')({ client: 'pg' });
    }

    async onModuleDestroy() {
        await this.$disconnect();
    }
}
