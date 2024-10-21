export interface UserGroup {
  group_id: number;
  user_id: number;
  roles_permissions_id: number;
  id?: number;
}

export interface JoinUserGroup {
  user_id: number;
  identification_string: string;
}
