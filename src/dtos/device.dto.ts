import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsUUID,
} from 'class-validator';
export class CreateDeviceDto {
  @IsString()
  @IsNotEmpty()
  public device_uuid: string;
}

export class DeleteDeviceDto{
  @IsNotEmpty()
  @IsNumber()
  user_id: number;

  @IsString()
  @IsNotEmpty()
  @IsUUID(4)
  device_uuid: string;

  @IsNotEmpty()
  @IsNumber()
  id: number;
}
