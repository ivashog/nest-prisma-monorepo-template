import { applyDecorators } from '@nestjs/common';
import { ApiProperty } from '@nestjs/swagger';
import { ArrayMaxSize, IsIn, IsOptional } from 'class-validator';
import { Transform } from 'class-transformer';

import { NOOP } from '../../utils';

export interface IsArrayOfEnumsOptions {
    enum: string[];
    isOptional?: boolean;
    apiDescription?: string;
}

export const IsArrayOfEnums = (options: IsArrayOfEnumsOptions) => {
    const { isOptional = false, apiDescription } = options;

    return applyDecorators(
        ApiProperty({
            type: [String],
            format: 'form',
            required: !isOptional,
            enum: options.enum || [],
            description: apiDescription ?? 'Comma separated enum values',
        }),
        isOptional ? IsOptional() : NOOP,
        ArrayMaxSize(options.enum.length),
        IsIn(options.enum, { each: true }),
        Transform((value: string) => (!!value ? value.split(',').map(_ => _.trim()) : null)),
    );
};
