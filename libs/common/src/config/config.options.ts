import { ConfigModuleOptions } from '@nestjs/config/dist/interfaces';

import { configValidationSchema } from './config.validation';
import { apiConfig } from './api';

export const defaultConfigOptions: ConfigModuleOptions = {
    isGlobal: true,
    envFilePath: ['.env.development.local', '.env.development', '.env'],
    expandVariables: true,
    validationSchema: configValidationSchema,
    validationOptions: {
        allowUnknown: true,
        abortEarly: false,
    },
    load: [apiConfig],
};
