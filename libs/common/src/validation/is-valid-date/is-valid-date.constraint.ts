import {
    ValidationArguments,
    ValidatorConstraint,
    ValidatorConstraintInterface,
} from 'class-validator';
import moment, { MomentInput } from 'moment';

import { IsValidDateOptions } from './is-valid-date.interface';

@ValidatorConstraint({ async: false })
export class IsValidDateConstraint implements ValidatorConstraintInterface {
    public validate(date: string, args: ValidationArguments): boolean {
        const { format, allowFuture, strict, min, max } = this.getConstraintsWithDefaults(
            args.constraints,
        );
        const parsedDate = moment(date, format, strict);
        const now = moment();

        if (!parsedDate.isValid()) return false;

        if (!allowFuture && !min && !max) {
            return parsedDate.isSameOrBefore(now);
        } else if (min && max) {
            return parsedDate.isBetween(min, max, undefined, '[]');
        } else if (!allowFuture && min) {
            return parsedDate.isBetween(min, now, undefined, '[]');
        } else {
            return min
                ? parsedDate.isSameOrAfter(min)
                : max
                ? parsedDate.isSameOrBefore(max)
                : true;
        }
    }

    public defaultMessage?(args?: ValidationArguments): string {
        const { format, min, max } = this.getConstraintsWithDefaults(args.constraints);
        return (
            `Date '${args.value}' is invalid! ` +
            `Allowed formats: '${format}'; allowed interval: ` +
            `from '${min ? this.formatDate(min, format as string) : 'any'}' ` +
            `to '${max ? this.formatDate(max, format as string) : this.formatDate()}'`
        );
    }

    private getConstraintsWithDefaults = ([
        { format = 'YYYY-MM-DD', strict = true, allowFuture = false, min, max },
    ]: IsValidDateOptions[]): IsValidDateOptions => ({ format, allowFuture, strict, min, max });

    private formatDate = (date?: MomentInput, format?: string): string =>
        moment(date || new Date()).format(format || 'YYYY-MM-DD');
}
