import { registerAs } from '@nestjs/config';
import path from 'path';
import * as fs from 'fs';

import { ApiConfig, ApiEnv, EnvType } from './api.interface';
import { API_CONF } from './api.constants';

const packageJsonFile = fs.readFileSync(path.resolve(process.cwd(), 'package.json'), {
    encoding: 'utf8',
});
const packageJson = JSON.parse(packageJsonFile);

export const apiConfig = registerAs(
    API_CONF,
    async (): Promise<ApiConfig> => {
        const ENV = process.env as ApiEnv;
        const appName = ENV.API_NAME || packageJson.name;

        return {
            env: ENV.NODE_ENV as EnvType,
            port: Number.parseInt(ENV.API_PORT, 10),
            apiPrefix: ENV.API_PREFIX,
            appName,
            version: packageJson.version,
            description: packageJson.description,
            isProduction: ENV.NODE_ENV === 'production',
            swagger: {
                isEnabled: ENV.SWAGGER_ENABLED === 'true',
                apiBaseUrl: ENV.SWAGGER_API_URL || `http://localhost:${ENV.API_PORT}`,
                uriPath: ENV.SWAGGER_URI_PATH,
                remoteServers: ENV.SWAGGER_REMOTE_SERVER_URLs?.split(',') ?? [],
            },
            apiMonitoring: {
                isEnabled: ENV.SW_STATS_ENABLED === 'true',
                swStatsOptions: {
                    name: appName,
                    version: packageJson.version,
                    uriPath: ENV.SW_STATS_URI_PATH,
                    timelineBucketDuration: Number.parseInt(
                        ENV.SW_STATS_TIMELINE_BUCKET_DURATION,
                        10,
                    ),
                    apdexThreshold: Number.parseInt(ENV.SW_STATS_APDEX_THRESHOLD, 10),
                    authentication: ENV.SW_STATS_AUTH === 'true',
                    onAuthenticate: (req, username, password) =>
                        username === ENV.SW_STATS_USER && password === ENV.SW_STATS_PASSWORD,
                    sessionMaxAge: Number.parseInt(ENV.SW_STATS_SESSION_MAX_AGE, 10),
                    // elasticsearch: isElasticEnabled ? ENV.ELASTIC_URL : undefined,
                    // elasticsearchIndexPrefix: isElasticEnabled ? ENV.ELASTIC_IDX_PREFIX : undefined,
                    // elasticsearchUsername: isElasticEnabled ? ENV.ELASTIC_USER : undefined,
                    // elasticsearchPassword: isElasticEnabled ? ENV.ELASTIC_PASSWORD : undefined,
                },
            },
        };
    },
);
