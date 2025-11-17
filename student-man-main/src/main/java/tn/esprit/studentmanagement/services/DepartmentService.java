package tn.esprit.studentmanagement.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import tn.esprit.studentmanagement.entities.Department;
import tn.esprit.studentmanagement.repositories.DepartmentRepository;

import java.util.List;
import java.util.Objects;

@Service

public class DepartmentService implements IDepartmentService {
    @Autowired
    DepartmentRepository departmentRepository;

    @Override
    public List<Department> getAllDepartments() {
        return departmentRepository.findAll();
    }

    @Override
    public Department getDepartmentById(Long idDepartment) {
        if (idDepartment == null) {
            throw new IllegalArgumentException("idDepartment must not be null");
        }
        long id = idDepartment;
        return departmentRepository.findById(id).orElse(null);
    }

    @Override
    @SuppressWarnings("null")
    public Department saveDepartment(Department department) {
        Department saved = departmentRepository.save(department);
        Objects.requireNonNull(saved, "Saved department must not be null");
        return saved;
    }

    @Override
    public void deleteDepartment(Long idDepartment) {
        if (idDepartment == null) {
            throw new IllegalArgumentException("idDepartment must not be null");
        }
        long id = idDepartment;
        departmentRepository.deleteById(id);
    }
}
