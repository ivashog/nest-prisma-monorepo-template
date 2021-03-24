import { Expose, Transform } from 'class-transformer';
import { IsIn, IsPositive, IsString, Max, Min } from 'class-validator';
import { Prisma } from '@prisma/client';
import { ApiHideProperty, ApiProperty } from '@nestjs/swagger';

export class PaginationDto {
    @Max(300)
    @IsPositive()
    @Transform(value => Number.parseInt(value))
    perPage?: number = 10;

    @Max(1000)
    @Min(1)
    @Transform(value => Number.parseInt(value))
    page?: number = 1;

    @IsString()
    orderBy?: string;

    @ApiProperty({ enum: Object.values(Prisma.SortOrder), default: Prisma.SortOrder.desc })
    @IsIn(Object.values(Prisma.SortOrder))
    orderDir?: Prisma.SortOrder = Prisma.SortOrder.desc;

    @ApiHideProperty()
    @Expose()
    @Transform((value: undefined, obj: PaginationDto) => obj.perPage * ((obj.page || 1) - 1))
    offset: number;
}
