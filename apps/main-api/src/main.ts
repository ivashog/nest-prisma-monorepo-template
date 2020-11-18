import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import compression from 'compression';

import { API_CONF, ApiConfig } from '@app/common/config';
import { initSwaggerModule } from '@app/common/swagger';

import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);
    const apiConfig = app.get(ConfigService).get<ApiConfig>(API_CONF);
    const { appName, port, swagger, apiMonitoring } = apiConfig;
    const logger = new Logger(appName);

    app.enableCors();
    app.use(compression());
    app.use(helmet({ contentSecurityPolicy: false }));

    initSwaggerModule(app, apiConfig);

    await app.listen(port);

    logger.log(`app is listening on port ${port}`);
    if (swagger.isEnabled) {
        logger.log(`Swagger is exposed at ${swagger.apiBaseUrl}${swagger.uriPath}`);
    }
    if (apiMonitoring.isEnabled) {
        logger.log(
            `Api monitoring is exposed at ${swagger.apiBaseUrl}${apiMonitoring.swStatsOptions.uriPath}/ui`,
        );
    }
}

bootstrap().catch(e => console.error(e));
