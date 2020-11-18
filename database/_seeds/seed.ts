#!/usr/bin/env node

import yargs from 'yargs';
import { PrismaClient } from '@prisma/client';
import { appendFileSync, readFileSync } from 'fs';
import path from 'path';

export type SeederFn<T extends Record<string, unknown>> = (
    prisma: PrismaClient,
    options?: { [x: string]: unknown },
) => Promise<(void | T)[]>;
export type Seeders = {
    [seeder: string]: SeederFn<any>;
};

const argv = yargs.options({
    env: {
        default: 'development',
        description: 'Name of environment (must matches with seeds folder)',
    },
    verbose: {
        type: 'boolean',
        default: false,
        description: 'Run with verbose logging',
    },
    amount: {
        type: 'number',
        description: 'Run seed with "amount" option (for generation "amount" seed objects)',
    },
}).argv;

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const { _, $0, env, verbose, ...options } = argv;
if (verbose && Object.keys(options).length > 0) {
    console.info('options:');
    console.table(options);
}

const main = async () => {
    const prisma = new PrismaClient();
    const seeders: Seeders = await import(`./${env}`);

    await Promise.all(
        Object.entries(seeders).map(async ([seederName, seederFn]) => {
            if (isSeedAlreadyExecuted(seederName, seederFn)) return;

            const result = await seederFn(prisma, options);
            if (verbose) {
                console.log(`>> Log result for ${seederName}:`);
                console.table(result);
            }

            return result;
        }),
    );

    console.log('\n>> DONE!');

    await prisma.$disconnect();
};

const isSeedAlreadyExecuted = (seederName: string, seederFn?: SeederFn<any>): boolean => {
    const LOCKFILE_PATH = path.resolve(__dirname, 'seed.lock');
    const lockfile = readFileSync(LOCKFILE_PATH, { encoding: 'utf-8' });

    if (seederFn && seederFn.length > 1) {
        seederName += `::${parseArgsToStr(options)}`;
    }
    const seedLog = `${Date.now()}-${seederName}`;
    const isSeedAlreadyExecuted = lockfile.includes(seederName);

    if (!isSeedAlreadyExecuted) {
        appendFileSync(LOCKFILE_PATH, '\n' + seedLog);
        console.log('+ ', seedLog);
    }

    return isSeedAlreadyExecuted;
};

const parseArgsToStr = (args: { [x: string]: unknown }): string =>
    Object.entries(args)
        .reduce((acc, [key, value]) => [...acc, `${key}=${value}`], [])
        .join(',');

main();
