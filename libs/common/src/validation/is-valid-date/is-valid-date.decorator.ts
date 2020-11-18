import { registerDecorator, ValidationOptions } from 'class-validator';

import { IsValidDateConstraint } from './is-valid-date.constraint';
import { IsValidDateOptions } from './is-valid-date.interface';

export function IsValidDate(options: IsValidDateOptions, validationOptions?: ValidationOptions) {
    // eslint-disable-next-line @typescript-eslint/ban-types
    return (object: object, propName: string) => {
        registerDecorator({
            name: 'IsValidDate',
            target: object.constructor,
            propertyName: propName,
            options: validationOptions,
            constraints: [options],
            validator: IsValidDateConstraint,
        });
    };
}
