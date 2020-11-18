import { MomentFormatSpecification } from 'moment';

export interface IsValidDateOptions {
    format?: MomentFormatSpecification;
    strict?: boolean;
    allowFuture?: boolean;
    min?: Date;
    max?: Date;
}
