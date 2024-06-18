import { IsNotEmpty, IsNumber, isObject, IsObject, IsString, IsUUID } from 'class-validator';

export class DeviceDto {
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

export class GroupDto {
  @IsNotEmpty()
  @IsNumber()
  id: number;

  @IsNumber()
  @IsNotEmpty()
  created_by_user_id: number;

  @IsString()
  @IsNotEmpty()
  name: string;
}

export class PushNotificationsDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  body: string;

  @IsObject()
  @IsNotEmpty()
  data: object;

  @IsNumber()
  @IsNotEmpty()
  push_notification_type_id: number;

  @IsNumber()
  id?: number;
}

export class CreatePushNotificationDto {
  @IsObject()
  device: DeviceDto;

  @IsObject()
  @IsNotEmpty()
  push_notification: PushNotificationsDto;

  @IsObject()
  group: GroupDto;
}
