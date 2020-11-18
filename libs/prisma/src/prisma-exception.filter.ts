import {
    ArgumentsHost,
    BadRequestException,
    Catch,
    ConflictException,
    GoneException,
    HttpException,
    InternalServerErrorException,
    NotFoundException,
} from '@nestjs/common';
import { BaseExceptionFilter } from '@nestjs/core';
import { PrismaClientKnownRequestError } from '@prisma/client';

import { PrismaErrorCodesEnum } from './prisma-error-codes.enum';
import { EnumValues } from 'enum-values';

export type PrismaError = PrismaClientKnownRequestError;

@Catch()
export class PrismaExceptionFilter extends BaseExceptionFilter {
    catch(exception: unknown, host: ArgumentsHost) {
        if (this.isPrismaException(exception)) {
            super.catch(this.parsePrismaError(exception), host);
        } else {
            super.catch(exception, host);
        }
    }

    protected isPrismaException = (err: unknown): err is PrismaError =>
        err instanceof PrismaClientKnownRequestError;

    protected parsePrismaError = (error: PrismaError): HttpException => {
        const exceptionArguments = [
            {
                type: 'DATABASE_ERROR',
                name: EnumValues.getNameFromValue(PrismaErrorCodesEnum, error.code),
                code: error.code,
                message: error.message,
                meta: error.meta,
            },
            error.message,
        ];

        switch (error.code) {
            case PrismaErrorCodesEnum.RecordNotFound:
            case PrismaErrorCodesEnum.ConnectedRecordsNotFound:
            case PrismaErrorCodesEnum.RelatedRecordNotFound:
                return new NotFoundException(...exceptionArguments);
            case PrismaErrorCodesEnum.InputValueTooLong:
            case PrismaErrorCodesEnum.StoredValueIsInvalid:
            case PrismaErrorCodesEnum.TypeMismatch:
            case PrismaErrorCodesEnum.TypeMismatchInvalidCustomType:
                return new BadRequestException(...exceptionArguments);
            case PrismaErrorCodesEnum.UniqueKeyViolation:
            case PrismaErrorCodesEnum.ForeignKeyViolation:
            case PrismaErrorCodesEnum.ConstraintViolation:
            case PrismaErrorCodesEnum.NullConstraintViolation:
            case PrismaErrorCodesEnum.RelationViolation:
                return new ConflictException(...exceptionArguments);
            case PrismaErrorCodesEnum.TableDoesNotExist:
            case PrismaErrorCodesEnum.ColumnDoesNotExist:
                return new GoneException(...exceptionArguments);
            default:
                return new InternalServerErrorException(...exceptionArguments);
        }
    };
}
