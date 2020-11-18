import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import moment from 'moment';

import { API_CONF, ApiConfig } from '@app/common/config';
import { ApiStatusResponseDto } from './api-status-response.dto';

@Injectable()
export class ApiStatusService {
    private readonly startTime: number;
    private readonly config: ApiConfig;

    constructor(private readonly configService: ConfigService) {
        this.startTime = Date.now();
        this.config = configService.get<ApiConfig>(API_CONF);
    }

    async getAppStatus(): Promise<ApiStatusResponseDto> {
        const { appName, version } = this.config;
        return {
            status: 'OK',
            name: appName,
            version,
            uptime: moment().to(this.startTime),
        };
    }
}
