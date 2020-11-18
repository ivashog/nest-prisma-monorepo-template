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
        const parsedMomentDate = moment(date, format, strict);
        const isValidFormat = parsedMomentDate.isValid();

        if (!isValidFormat) return false;

        const parsedDate = parsedMomentDate.toDate();

        if (!allowFuture && !min && !max) {
            return parsedDate <= new Date();
        } else if (min && max) {
            return min <= parsedDate && max >= parsedDate;
        } else if (!allowFuture) {
            return min
                ? min <= parsedDate && parsedDate <= new Date()
                : max
                ? max >= parsedDate && parsedDate <= new Date()
                : true;
        } else {
            return min ? min <= parsedDate : max ? max >= parsedDate : true;
        }
    }

    public defaultMessage?(args?: ValidationArguments): string {
        const { format, min, max } = this.getConstraintsWithDefaults(args.constraints);
        return (
            `Date '${args.value}' is invalid! ` +
            `Allowed formats: '${format}'; allowed interval: ` +
            `from '${min ? this.formatDate(min) : 'any'}' ` +
            `to '${max ? this.formatDate(max) : this.formatDate()}'`
        );
    }

    private getConstraintsWithDefaults = ([
        { format = 'YYYY-MM-DD', strict = true, allowFuture = false, min, max },
    ]: IsValidDateOptions[]): IsValidDateOptions => ({ format, allowFuture, strict, min, max });

    private formatDate = (date?: MomentInput, format?: string): string =>
        moment(date || new Date()).format(format || 'YYYY-MM-DD');
}
