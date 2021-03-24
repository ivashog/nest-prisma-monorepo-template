import { applyDecorators } from '@nestjs/common';
import { IsInt, Max, Min } from 'class-validator';
import { Transform } from 'class-transformer';

import { TileParam } from '@app/common/interfaces';
import { NOOP } from '@app/common/utils';

export const IsXYZParam = (max?: number) =>
    applyDecorators(
        max ? Max(max) : NOOP,
        Min(0),
        IsInt(),
        Transform(val => Number(val)),
    );

export class MvtParamsDto implements TileParam {
    /**
     * @example 8
     */
    @IsXYZParam(22)
    z: number;

    /**
     * @example 149
     */
    @IsXYZParam()
    x: number;

    /**
     * @example 86
     */
    @IsXYZParam()
    y: number;
}
