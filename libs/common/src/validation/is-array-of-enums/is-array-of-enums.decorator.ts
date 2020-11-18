import { applyDecorators } from '@nestjs/common';
import { ApiProperty } from '@nestjs/swagger';
import { ArrayMaxSize, IsIn, IsOptional } from 'class-validator';
import { Transform } from 'class-transformer';

import { NOOP } from '../../utils';
import { EnumValues } from 'enum-values';

export interface IsArrayOfEnumsOptions {
    enum: any;
    isOptional?: boolean;
    apiDescription?: string;
}

export const IsArrayOfEnums = (options: IsArrayOfEnumsOptions) => {
    const { isOptional = false, apiDescription } = options;
    const enumValues = EnumValues.getValues(options.enum);

    return applyDecorators(
        ApiProperty({
            type: [String],
            format: 'form',
            required: !isOptional,
            description: apiDescription ?? 'Comma separated enum values',
        }),
        isOptional ? IsOptional() : NOOP,
        ArrayMaxSize(enumValues.length),
        IsIn(EnumValues.getValues(options.enum), { each: true }),
        Transform((value: string) => (!!value ? value.split(',') : null)),
    );
};
