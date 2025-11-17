package tn.esprit.studentmanagement.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import tn.esprit.studentmanagement.repositories.EnrollmentRepository;
import tn.esprit.studentmanagement.entities.Enrollment;
import java.util.List;

@Service
public class EnrollmentService implements IEnrollment {
    @Autowired
    EnrollmentRepository enrollmentRepository;

    @Override
    public List<Enrollment> getAllEnrollments() {
        return enrollmentRepository.findAll();
    }

    @Override
    public Enrollment getEnrollmentById(Long idEnrollment) {
        if (idEnrollment == null) {
            throw new IllegalArgumentException("idEnrollment must not be null");
        }
        long id = idEnrollment;
        return enrollmentRepository.findById(id).orElse(null);
    }

    @Override
    @SuppressWarnings("null")
    public Enrollment saveEnrollment(Enrollment enrollment) {
        Enrollment saved = enrollmentRepository.save(enrollment);
        return saved;
    }

    @Override
    public void deleteEnrollment(Long idEnrollment) {
        if (idEnrollment == null) {
            throw new IllegalArgumentException("idEnrollment must not be null");
        }
        long id = idEnrollment;
        enrollmentRepository.deleteById(id);
    }
}
