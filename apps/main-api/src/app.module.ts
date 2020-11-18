import { Module, ValidationPipe } from '@nestjs/common';
import { APP_FILTER, APP_INTERCEPTOR, APP_PIPE } from '@nestjs/core';
import { ConfigModule } from '@nestjs/config';

import { loadAppConfig } from '@app/common/config';
import { ApiStatusModule } from '@app/common/api-status';
import { LoggingInterceptor } from '@app/common/interceptors';
import { PrismaExceptionFilter } from '@app/prisma';

@Module({
    imports: [ConfigModule.forRoot(loadAppConfig({ appName: 'main-api' })), ApiStatusModule],
    providers: [
        {
            provide: APP_PIPE,
            useValue: new ValidationPipe({
                transform: true,
            }),
        },
        {
            provide: APP_INTERCEPTOR,
            useClass: LoggingInterceptor,
        },
        {
            provide: APP_FILTER,
            useClass: PrismaExceptionFilter,
        },
    ],
})
export class AppModule {}
