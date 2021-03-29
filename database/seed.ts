import { PrismaClient } from '@prisma/client';
import Faker from 'faker/locale/uk';

const prisma = new PrismaClient();

async function main() {
    const { count } = await prisma.model.createMany({
        data: new Array(100).fill(null).map(_ => ({
            key: Faker.unique(Faker.random.alphaNumeric, [10]),
            name: Faker.company.companyName(),
        })),
        skipDuplicates: true,
    });
    console.log(`Created ${count} fake models`);
}
main()
    .catch(e => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
