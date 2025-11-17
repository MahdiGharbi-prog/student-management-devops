package tn.esprit.studentmanagement.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import tn.esprit.studentmanagement.entities.Student;
import tn.esprit.studentmanagement.repositories.StudentRepository;
import java.util.Objects;

import java.util.List;

@Service
public class StudentService implements IStudentService {
    @Autowired
    private StudentRepository studentRepository;

    public List<Student> getAllStudents() {
        return studentRepository.findAll();
    }

    public Student getStudentById(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("id must not be null");
        }
        long lid = id;
        return studentRepository.findById(lid).orElse(null);
    }

    @SuppressWarnings("null")
    public Student saveStudent(Student student) {
        Student saved = studentRepository.save(student);
        Objects.requireNonNull(saved, "Saved student must not be null");
        return saved;
    }

    public void deleteStudent(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("id must not be null");
        }
        long lid = id;
        studentRepository.deleteById(lid);
    }

}
