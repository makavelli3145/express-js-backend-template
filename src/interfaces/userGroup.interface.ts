export interface UserGroup {
  group_id: number;
  user_id: number;
  user_group_permissions: number;
  id?: number;
}

export interface JoinUserGroup {
  user_id: number;
  identification_string: string;
}
