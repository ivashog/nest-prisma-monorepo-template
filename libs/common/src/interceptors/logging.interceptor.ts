import {
    CallHandler,
    ExecutionContext,
    HttpException,
    Injectable,
    Logger,
    NestInterceptor,
} from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { Request } from 'express';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
    intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
        const now = Date.now();

        return next.handle().pipe(
            tap(() => {
                this.logSuccess(context, now);
            }),
            catchError(err => {
                this.logError(context, err);
                return throwError(err);
            }),
        );
    }

    protected logSuccess = (context: ExecutionContext, reqTime: number): string => {
        const caller = context.getClass().name;
        const { method, url, ip, headers } = context.switchToHttp().getRequest<Request>();
        const reqIp = headers['x-real-ip'] ?? headers['x-forwarded-for'] ?? ip;
        const message = `[${reqIp}] ${method} ${url} per ${Date.now() - reqTime} ms`;

        Logger.log(message, caller);

        return message;
    };

    protected logError = (
        context: ExecutionContext,
        err: Error | HttpException,
    ): { error: string; errorDetail?: string } => {
        const caller = context.getClass().name;
        const { method, url, ip, headers } = context.switchToHttp().getRequest<Request>();
        const reqIp = headers['x-real-ip'] ?? headers['x-forwarded-for'] ?? ip;
        const error = this._isHttpException(err)
            ? (err as any).getResponse()?.error || ''
            : err.message;

        const errorDetail = this._isHttpException(err)
            ? (err as any).getResponse()?.message
            : undefined;

        Logger.error(
            `[${reqIp}] ${method} ${url} Error: ${error}`,
            errorDetail ?? error.stack,
            caller,
            false,
        );

        return { error, errorDetail };
    };

    private _isHttpException = (error: any): error is HttpException =>
        error instanceof HttpException;
}
