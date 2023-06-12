﻿using System;
using System.Collections.Generic;

namespace Syren.QuickCartDAL.Models;

public partial class Role
{
    public byte RoleId { get; set; }

    public string RoleName { get; set; } = null!;

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
