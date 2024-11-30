package br.com.sigas.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import br.com.sigas.entities.Operacoes;
import br.com.sigas.services.OperacoesService;

@RestController
@RequestMapping("/operacoes")
public class OperacoesController {

    @Autowired
    private OperacoesService operacoesService;

    @PostMapping
    public ResponseEntity<?> inserirOperacao(@RequestBody Operacoes operacao) {
        try {
            // Obtenha o ID da pessoa diretamente do JSON
            Long id_pessoa = operacao.getPessoa().getId_pessoa();

            // Chame o serviço para criar a operação
            operacoesService.inserirOperacao(operacao, id_pessoa);

            return ResponseEntity.ok("Operação criada com sucesso!");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao criar operação: " + e.getMessage());
        }
    }

    @GetMapping("id/{id}")
    public ResponseEntity<?> buscarOperacaoPorId(@PathVariable Integer id) {
        try {
            return ResponseEntity.ok(operacoesService.buscarOperacaoPorId(id));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar operação: " + e.getMessage());
        }
    }

    @GetMapping("pessoa/{id}")
    public ResponseEntity<?> buscarOperacoesPorPessoa(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(operacoesService.buscarOperacoesPorPessoa(id));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar operações: " + e.getMessage());
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> atualizarOperacao(@PathVariable Integer id, @RequestBody Operacoes operacaoAtualizada) {
        try {
            operacoesService.atualizarOperacao(id, operacaoAtualizada);
            return ResponseEntity.ok("Operação atualizada com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao atualizar operação: " + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deletarOperacao(@PathVariable Integer id) {
        try {
            operacoesService.deletarOperacao(id);
            return ResponseEntity.ok("Operação deletada com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao deletar operação: " + e.getMessage());
        }
    }
}
