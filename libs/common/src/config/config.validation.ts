import Joi from '@hapi/joi';

import { apiValidationSchema } from './api';

export const configValidationSchema = Joi.object(Object.assign({}, apiValidationSchema));
