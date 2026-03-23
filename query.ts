import { rawPrisma } from './permission-protocol-repo/src/lib/company/raw-prisma';

async function main() {
  const req = await rawPrisma.deployGateRequest.findFirst({
    where: { prNumber: 212 },
    orderBy: { createdAt: 'desc' },
  });
  console.log(JSON.stringify(req, null, 2));
}

main().catch(console.error);
