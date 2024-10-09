package com.bansikah.bookbackend.service;


import com.bansikah.bookbackend.domain.Book;
import com.bansikah.bookbackend.repository.BookRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;

@Service
public class BookService {

    @Autowired
    private BookRepository bookRepository;

    private final String UPLOAD_DIR = "uploads/";

    public Book createBook(String title, String author, MultipartFile file) throws IOException {
        Path uploadPath = Paths.get(UPLOAD_DIR + file.getOriginalFilename());
        Files.createDirectories(uploadPath.getParent());
        Files.write(uploadPath, file.getBytes());

        Book book = new Book();
        book.setTitle(title);
        book.setAuthor(author);
        book.setFilePath(uploadPath.toString());
        return bookRepository.save(book);
    }

    public List<Book> getAllBooks() {
        return bookRepository.findAll();
    }

    public Optional<Book> getBookById(Long id) {
        return bookRepository.findById(id);
    }

    public Book updateBook(Long id, String title, String author, MultipartFile file) throws IOException {
        Book book = bookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Book not found with id " + id));

        if (file != null) {
            Path uploadPath = Paths.get(UPLOAD_DIR + file.getOriginalFilename());
            Files.createDirectories(uploadPath.getParent());
            Files.write(uploadPath, file.getBytes());
            book.setFilePath(uploadPath.toString());
        }

        book.setTitle(title);
        book.setAuthor(author);
        return bookRepository.save(book);
    }

    public void deleteBook(Long id) {
        bookRepository.deleteById(id);
    }
}
