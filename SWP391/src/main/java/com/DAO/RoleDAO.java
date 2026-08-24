package com.DAO;

import com.entity.Role;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO extends DBContext{
    public List<Role> fillAllRole() {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT * FROM role";
        try {
            connection = new DBContext().connection;
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                Role role = new Role();
                role.setId(resultSet.getInt("id"));
                role.setRoleName(resultSet.getString("name"));
                roles.add(role);
            }
        } catch (SQLException ex) {
            System.out.println(ex.getMessage());
        } finally {
            closeResources();
        }
        return roles;
    }
}
