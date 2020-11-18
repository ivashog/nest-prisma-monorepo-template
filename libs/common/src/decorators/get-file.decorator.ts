import { BadRequestException, createParamDecorator, ExecutionContext } from '@nestjs/common';
import { ValueOf } from '../interfaces/types';

export const GetFile = createParamDecorator<
    keyof Express.Multer.File,
    ExecutionContext,
    ValueOf<Express.Multer.File>
>((fileProp, ctx) => {
    const request = ctx.switchToHttp().getRequest();
    const file = request.file;

    if (!file) {
        throw new BadRequestException('The request body does not contain a file!');
    }

    return fileProp ? file && file[fileProp] : file;
});
