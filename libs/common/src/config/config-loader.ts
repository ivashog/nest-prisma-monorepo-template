import { ConfigModuleOptions } from '@nestjs/config/dist/interfaces';
import { ConfigFactory } from '@nestjs/config/dist/interfaces/config-factory.interface';
import Joi, { ObjectSchema, SchemaMap } from '@hapi/joi';
import path from 'path';

import { defaultConfigOptions } from './config.options';

export const getEnvFilesByAppName = (appName: string): string[] => {
    const environment = process.env.NODE_ENV || 'development';
    const cascadeEnv = [`.env.${environment}.local`, `.env.${environment}`, '.env.local', '.env'];
    return cascadeEnv
        .map(env => path.resolve('environment', appName, env))
        .concat(cascadeEnv.map(env => path.resolve('environment', env)));
};

export interface LoadAppConfigOptions {
    appName: string;
    config?: {
        load: Array<ConfigFactory>;
        validationSchema: ObjectSchema<Required<SchemaMap<Record<string, any>>>>;
    };
    useDefault?: boolean;
}

export const loadAppConfig = (options: LoadAppConfigOptions): ConfigModuleOptions => {
    const { appName, config, useDefault = true } = options;

    return {
        ...defaultConfigOptions,
        envFilePath: getEnvFilesByAppName(appName),
        validationSchema: config
            ? config.validationSchema.concat(
                  useDefault ? defaultConfigOptions.validationSchema : Joi.object({}),
              )
            : defaultConfigOptions.validationSchema,
        load: config
            ? config.load.concat(useDefault ? defaultConfigOptions.load : [])
            : defaultConfigOptions.load,
    };
};
