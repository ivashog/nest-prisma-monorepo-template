import { applyDecorators } from '@nestjs/common';
import { ApiHeader, ApiNotFoundResponse, ApiOkResponse } from '@nestjs/swagger';

import { MIME, NoCompressionHeader } from '@app/common/enums';
import { MvtError } from '../errors/mvt.error';

export const ApiMvtResponse = () =>
    applyDecorators(
        ApiOkResponse({
            description: 'Return Mapbox Vector Tile (MVT) binary data',
            content: {
                [MIME.mvt]: {
                    schema: {
                        type: 'string',
                        format: 'binary',
                    },
                },
            },
        }),
        ApiNotFoundResponse({
            description: 'Tile not found error',
            type: MvtError,
        }),
        ApiHeader({
            name: 'x-no-compression',
            description: 'Disable compression custom header',
            enum: NoCompressionHeader,
            required: false,
        }),
    );
