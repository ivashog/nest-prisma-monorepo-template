import { default as Joi, SchemaMap } from '@hapi/joi';

import { ApiEnv } from './api.interface';

export const apiValidationSchema: Required<SchemaMap<ApiEnv>> = {
    NODE_ENV: Joi.string().valid('development', 'production', 'testing').default('development'),
    API_PORT: Joi.number().port().required(),
    API_NAME: Joi.string().max(255).optional(),
    API_PREFIX: Joi.string().allow('').uri({ relativeOnly: true }).optional(),
    SWAGGER_ENABLED: Joi.boolean().default(false),
    SWAGGER_API_URL: Joi.string().uri().optional(),
    SWAGGER_URI_PATH: Joi.string().uri({ relativeOnly: true }).optional(),
    SWAGGER_REMOTE_SERVER_URLs: Joi.string().uri().optional(),

    SW_STATS_ENABLED: Joi.boolean().default(false),
    SW_STATS_URI_PATH: Joi.string().uri({ relativeOnly: true }).optional(),
    SW_STATS_AUTH: Joi.boolean().default(false),
    SW_STATS_USER: Joi.string().default('sw_user'),
    SW_STATS_PASSWORD: Joi.string().default('sw_password'),
    SW_STATS_SESSION_MAX_AGE: Joi.number().positive().integer().optional(),
    SW_STATS_TIMELINE_BUCKET_DURATION: Joi.number()
        .integer()
        .min(10000) // 10 seconds
        .optional(),
    SW_STATS_APDEX_THRESHOLD: Joi.number().integer().valid(25, 50, 100).optional(),
    SW_STATS_ELASTIC: Joi.boolean().default(false),
    // ELASTIC_URL: Joi.string()
    //     .uri()
    //     .optional(),
    // ELASTIC_IDX_PREFIX: Joi.string().default('api-logs-'),
    // ELASTIC_USER: Joi.string().optional(),
    // ELASTIC_PASSWORD: Joi.string().optional(),
};
