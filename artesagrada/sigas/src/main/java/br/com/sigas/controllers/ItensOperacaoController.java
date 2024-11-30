package br.com.sigas.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import br.com.sigas.entities.ItensOperacao;
import br.com.sigas.services.ItensOperacaoService;

@RestController
@RequestMapping("/itens-operacao")
public class ItensOperacaoController {

    @Autowired
    private ItensOperacaoService itensOperacaoService;

    @PostMapping
    public ResponseEntity<?> criarItemOperacao(@RequestBody ItensOperacao itemOperacao) {
        try {
            itensOperacaoService.inserirItemOperacao(itemOperacao);
            return ResponseEntity.status(HttpStatus.CREATED).body("Item de operação criado com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao criar item de operação: " + e.getMessage());
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> atualizarItemOperacao(@PathVariable Long id, @RequestBody ItensOperacao itemAtualizado) {
        try {
            itensOperacaoService.atualizarItemOperacao(id, itemAtualizado);
            return ResponseEntity.ok("Item de operação atualizado com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao atualizar item de operação: " + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deletarItemOperacao(@PathVariable Long id) {
        try {
            itensOperacaoService.deletarItemOperacao(id);
            return ResponseEntity.ok("Item de operação deletado com sucesso.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao deletar item de operação: " + e.getMessage());
        }
    }
}
