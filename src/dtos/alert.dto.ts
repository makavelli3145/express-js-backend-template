import {IsNotEmpty, IsNumber, IsOptional, IsString, Matches} from 'class-validator';

export class CreateAlertDto {
  @IsString()
  @IsNotEmpty()
  public device_uuid: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^-?\d+(\.\d+)?\|-?\d+(\.\d+)?$/, {
    message: 'location must be in the format <longitude>|<latitude>',
  })
  public location: string;

  @IsNumber()
  @IsNotEmpty()
  public status_id: number;

  @IsNumber()
  @IsNotEmpty()
  public type_id: number;

  @IsString()
  @IsOptional()
  @Matches(/^[A-Z][a-z]+\s\d{2}:\d{2}$/, {
    message: 'alert schedule time must be a string in the format <day> <HH:MM>',
  })
  public alert_scheduled_time?: string;

  @IsString()
  @IsOptional()
  public message?: string;

  @IsNumber()
  @IsOptional()
  public recurring_alert_end_user_id?: number;
}

export class UpdateAlertDto extends CreateAlertDto {
  @IsNumber()
  @IsNotEmpty()
  public id: number;
}

export class DeleteAlertDto extends UpdateAlertDto {}
