import { Controller, Get } from '@nestjs/common';
import { ApiStatusService } from './api-status.service';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

@Controller()
@ApiTags('API status')
export class ApiStatusController {
    constructor(private readonly appService: ApiStatusService) {}

    @Get()
    @ApiOperation({ summary: 'Check application status' })
    getStatus() {
        return this.appService.getAppStatus();
    }
}
