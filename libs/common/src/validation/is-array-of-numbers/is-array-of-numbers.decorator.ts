import { applyDecorators } from '@nestjs/common';
import { ApiProperty } from '@nestjs/swagger';
import { ArrayMaxSize, IsInt, IsNumber, Max, Min, IsOptional } from 'class-validator';
import { Transform } from 'class-transformer';

import { isString, NOOP } from '../../utils';

export interface IsArrayOfNumbersOptions {
    isDecimal?: boolean;
    max?: number;
    min?: number;
    maxSize?: number;
    isOptional?: boolean;
    apiDescription?: string;
}

export const IsArrayOfNumbers = (options?: IsArrayOfNumbersOptions) => {
    const { isDecimal = false, isOptional = false, max, min, maxSize } = options ?? {};
    return applyDecorators(
        ApiProperty({
            type: [Number],
            format: 'form',
            required: !isOptional,
            description: options.apiDescription ?? 'Comma separated numbers',
        }),
        isOptional ? IsOptional() : NOOP,
        maxSize ? ArrayMaxSize(maxSize) : NOOP,
        !isDecimal ? IsInt({ each: true }) : IsNumber({}, { each: true }),
        min ? Min(min, { each: true }) : NOOP,
        max ? Max(max, { each: true }) : NOOP,
        Transform((value: string | number[]) =>
            !!value
                ? isString(value)
                    ? (value as string)
                          .split(',')
                          .map(v => (!isDecimal ? Number.parseInt(v, 10) : Number.parseFloat(v)))
                    : value
                : null,
        ),
    );
};
