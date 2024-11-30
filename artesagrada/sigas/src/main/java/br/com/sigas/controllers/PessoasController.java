package br.com.sigas.controllers;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import br.com.sigas.entities.Pessoas;
import br.com.sigas.services.PessoasService;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
@RequestMapping("/pessoas")
public class PessoasController {

    @Autowired
    private PessoasService pessoaService;

    @PostMapping("/inserir")
    public ResponseEntity<?> inserirPessoa(@RequestBody Map<String, Object> dados) {
        try {
            pessoaService.inserirPessoa(dados);
            return ResponseEntity.ok("Pessoa inserida com sucesso!");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao inserir pessoa: " + e.getMessage());
        }
    }

    @GetMapping("/buscar/id/{id}")
    public ResponseEntity<?> buscarPessoaPorId(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(pessoaService.buscarPessoaPorId(id));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar pessoa: " + e.getMessage());
        }
    }

    @GetMapping("/buscar/nome/{nome}")
    public ResponseEntity<?> buscarPessoasPorNome(@PathVariable String nome) {
        try {
            return ResponseEntity.ok(pessoaService.buscarPessoasPorNome(nome));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar pessoas: " + e.getMessage());
        }
    }

    @GetMapping("/buscar/email/{email}")
    public ResponseEntity<?> buscarPessoasPorEmailContendo(@PathVariable String email) {
        try {
            return ResponseEntity.ok(pessoaService.buscarPessoasPorEmailContendo(email));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar pessoas: " + e.getMessage());
        }
    }

    @GetMapping("/buscar/ativos")
    public ResponseEntity<?> buscarPessoasAtivas() {
        try {
            return ResponseEntity.ok(pessoaService.buscarPessoasAtivas());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar pessoas: " + e.getMessage());
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> atualizarPessoa(@PathVariable Long id,
            @RequestBody Pessoas pessoaAtualizada) {
        try {
            pessoaService.atualizarPessoaProcedure(id, pessoaAtualizada);
            return ResponseEntity.ok("Pessoa atualizada com sucesso!");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao atualizar pessoa: " + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deletarPessoa(@PathVariable Long id) {
        try {
            pessoaService.deletarPessoaProcedure(id);
            return ResponseEntity.ok("Pessoa deletada com sucesso!");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao deletar pessoa: " + e.getMessage());
        }
    }
}
