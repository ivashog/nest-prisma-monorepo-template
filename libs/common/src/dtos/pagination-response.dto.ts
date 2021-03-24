export class PaginationResponseDto {
    readonly items?: number;
    readonly perPage?: number;
    readonly page?: number;
    readonly pages: number;
    readonly data: Record<string, any>[];
}
