import { EnvObject } from '../config.interface';
import { SWStats } from 'swagger-stats';

export type EnvType = 'development' | 'production' | 'testing';

export interface ApiEnv extends EnvObject {
    NODE_ENV: EnvType;
    API_PORT: string;
    API_NAME: string;
    API_PREFIX: string;
    SWAGGER_ENABLED: string;
    SWAGGER_API_URL: string;
    SWAGGER_URI_PATH: string;
    SWAGGER_REMOTE_SERVER_URLs: string;
    SW_STATS_ENABLED: string;
    SW_STATS_URI_PATH: string;
    SW_STATS_AUTH: string;
    SW_STATS_USER: string;
    SW_STATS_PASSWORD: string;
    SW_STATS_SESSION_MAX_AGE: string;
    SW_STATS_TIMELINE_BUCKET_DURATION: string;
    SW_STATS_APDEX_THRESHOLD: string;
    SW_STATS_ELASTIC?: string;
    // ELASTIC_URL?: string;
    // ELASTIC_IDX_PREFIX?: string;
    // ELASTIC_USER?: string;
    // ELASTIC_PASSWORD?: string;
}

export interface ApiConfig {
    env: EnvType;
    port: number;
    apiPrefix?: string;
    appName: string;
    version: string;
    description: string;
    isProduction: boolean;
    swagger: {
        isEnabled: boolean;
        apiBaseUrl: string;
        uriPath?: string;
        remoteServers?: string[];
    };
    apiMonitoring: {
        isEnabled: boolean;
        swStatsOptions?: SWStats;
    };
}
