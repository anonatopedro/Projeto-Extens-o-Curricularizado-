package br.com.sigas.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import br.com.sigas.entities.Produtos;
import br.com.sigas.services.ProdutosService;
import jakarta.persistence.EntityNotFoundException;

@RestController
@RequestMapping("/produtos")
public class ProdutosController {

    @Autowired
    private ProdutosService produtosService;

    @PostMapping
    public ResponseEntity<?> criarProduto(@RequestBody Produtos produto) {
        try {
            produtosService.criarProduto(produto);
            return ResponseEntity.status(HttpStatus.CREATED).body("Produto criado com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao criar produto: " + e.getMessage());
        }
    }

    @GetMapping("/id/{id}")
    public ResponseEntity<?> buscarProdutoPorId(@PathVariable Long id) {
        try {
            Produtos produto = produtosService.buscarProdutoPorId(id);
            return ResponseEntity.ok(produto);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Produto não encontrado.");
        }
    }

    @GetMapping("/categoria/{idCategoria}")
    public ResponseEntity<?> buscarProdutosPorCategoria(@PathVariable Long idCategoria) {
        try {
            List<Produtos> produtos = produtosService.buscarProdutosPorCategoria(idCategoria);
            if (produtos.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Produtos não encontrados.");
            }
            return ResponseEntity.ok(produtos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar produtos: " + e.getMessage());
        }
    }

    @GetMapping("/nome/{nomeProduto}")
    public ResponseEntity<?> buscarProdutoPorNome(@PathVariable String nomeProduto) {
        try {
            List<Produtos> produtos = produtosService.buscarProdutoPorNome(nomeProduto);
            if (produtos.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Produtos não encontrados.");
            }
            return ResponseEntity.ok(produtos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar produtos: " + e.getMessage());
        }
    }

    @PutMapping("/produtos/{id}")
    public ResponseEntity<?> atualizarProduto(
            @PathVariable Long id,
            @RequestBody Produtos produtoAtualizado) {
        try {
            // Chamar o serviço para atualizar o produto
            produtosService.atualizarProduto(id, produtoAtualizado);
            return ResponseEntity.ok("Produto atualizado com sucesso!");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao atualizar produto: " + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deletarProduto(@PathVariable Long id) {
        try {
            produtosService.deletarProduto(id);
            return ResponseEntity.ok("Produto desativado com sucesso.");
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Produto não encontrado.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao deletar produto: " + e.getMessage());
        }
    }
}
