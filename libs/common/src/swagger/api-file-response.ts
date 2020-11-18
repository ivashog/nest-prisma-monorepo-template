import { applyDecorators } from '@nestjs/common';
import { ApiBadRequestResponse, ApiNotFoundResponse, ApiOkResponse } from '@nestjs/swagger';

import { MIME } from '../enums/mime.enum';

class HttpExceptionResponseDto {
    statusCode: number;
    message: string;
    error: string;
}

export const ApiFileResponse = (...mimeTypes: MIME[]) =>
    applyDecorators(
        ApiOkResponse({
            description: 'Generated file download link',
            content: mimeTypes.reduce(
                (content, mime) => ({
                    ...content,
                    [mime]: {
                        type: 'string',
                        format: 'binary',
                    },
                }),
                {},
            ),
        }),
        ApiBadRequestResponse({
            description: 'Validation error',
            type: HttpExceptionResponseDto,
        }),
        ApiNotFoundResponse({
            description: 'Not found error',
            type: HttpExceptionResponseDto,
        }),
    );
