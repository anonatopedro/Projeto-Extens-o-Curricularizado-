package br.com.sigas.controllers;

import br.com.sigas.entities.Categorias;
import br.com.sigas.services.CategoriasService;
import jakarta.persistence.EntityNotFoundException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/categorias")
public class CategoriaController {

    @Autowired
    private CategoriasService categoriaService;

    @PostMapping
    public ResponseEntity<?> criarCategoria(@RequestBody Categorias categoria) {
        try {
            categoriaService.criarCategoria(categoria);
            return ResponseEntity.ok("Categoria criada com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Erro ao criar categoria: " + e.getMessage());
        }
    }

    @GetMapping("/id/{id}")
    public ResponseEntity<?> buscarPorId(@PathVariable Long id) {
        try {
            Categorias categoria = categoriaService.buscarPorId(id);
            return ResponseEntity.ok(categoria);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Categoria não encontrada.");
        }
    }

    @GetMapping("/nome/{nomeCategoria}")
    public ResponseEntity<?> buscarPorNome(@PathVariable String nomeCategoria) {
        try {
            List<Categorias> categorias = categoriaService.buscarPorNome(nomeCategoria);
            return ResponseEntity.ok(categorias);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Erro ao buscar categorias: " + e.getMessage());
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> atualizarCategoria(@PathVariable Long id, @RequestBody Categorias categoriaAtualizada) {
        try {
            categoriaService.atualizarCategoria(id, categoriaAtualizada);
            return ResponseEntity.ok("Categoria atualizada com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Erro ao atualizar categoria: " + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deletarCategoria(@PathVariable Long id) {
        try {
            categoriaService.deletarCategoria(id);
            return ResponseEntity.ok("Categoria deletada com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Erro ao deletar categoria: " + e.getMessage());
        }
    }
}
