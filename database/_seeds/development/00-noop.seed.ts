import { PrismaClient } from '@prisma/client';
import { SeederFn } from '../seed';

const testData = [{ message: 'This is a noop seeder function.' }, { message: 'Seeder work!' }];

export const noopSeed00: SeederFn<any> = (prisma: PrismaClient) =>
    Promise.all(testData.map(dataItem => prisma.$queryRaw`SELECT ${dataItem.message} as message`));
