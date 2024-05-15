import { PrismaClient } from '@prisma/client';
import {prismaExtension} from '@detail-dev/trace';

declare global {
  namespace NodeJS {
    interface Global {}
  }
}

// add prisma to the NodeJS global type
interface CustomNodeJsGlobal extends NodeJS.Global {
  prisma: PrismaClient;
}

// Prevent multiple instances of Prisma Client in development
declare const global: CustomNodeJsGlobal;

const prisma = global.prisma || new PrismaClient().$extends(prismaExtension) as PrismaClient;

if (process.env.NODE_ENV === 'development') {
  global.prisma = prisma;
}

export default prisma;
