import { ApiPropertyOptional, ApiResponseProperty } from '@nestjs/swagger';
import { TileParam } from '../interfaces/tile.param.interface';

export class MvtError extends Error {
    constructor(tile: TileParam, error?: string) {
        super();
        this.name = 'MvtError';
        this.message = `Tile '${tile.z}/${tile.x}/${tile.y}' is not ${error ? 'exists' : 'found'}!`;
        this.error = error;
    }

    @ApiResponseProperty()
    public name: string;

    @ApiResponseProperty()
    public message: string;

    @ApiPropertyOptional()
    public error?: string;
}
