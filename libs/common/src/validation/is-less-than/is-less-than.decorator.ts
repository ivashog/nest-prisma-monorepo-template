import { registerDecorator, ValidationOptions } from 'class-validator';

import { IsLessThanConstraint } from './is-less-than.constraint';
import { IsLessThanOptions } from './is-less-than.interface';

export function IsLessThan(options: IsLessThanOptions, validationOptions?: ValidationOptions) {
    // eslint-disable-next-line @typescript-eslint/ban-types
    return (object: object, propertyName: string) => {
        registerDecorator({
            name: 'IsValidMime',
            target: object.constructor,
            propertyName: propertyName,
            options: validationOptions,
            constraints: [...options],
            validator: IsLessThanConstraint,
        });
    };
}
