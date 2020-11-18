import {
    ValidationArguments,
    ValidatorConstraint,
    ValidatorConstraintInterface,
} from 'class-validator';
import { IsLessThanOptions } from './is-less-than.interface';

@ValidatorConstraint()
export class IsLessThanConstraint implements ValidatorConstraintInterface {
    public validate(value: any, args: ValidationArguments): boolean {
        const [compareProperty, isInclusive = false] = args.constraints as IsLessThanOptions;
        const compareValue = (args.object as any)[compareProperty];
        const isComparable = typeof value === 'number' && typeof compareValue === 'number';

        return isComparable && (isInclusive ? value <= compareValue : value < compareValue);
    }

    public defaultMessage?(args?: ValidationArguments): string {
        const [compareProperty, isInclusive = false] = args.constraints as IsLessThanOptions;

        return `Value must be less than ${
            isInclusive ? 'or equal' : ''
        } to '${compareProperty}' value`;
    }
}
