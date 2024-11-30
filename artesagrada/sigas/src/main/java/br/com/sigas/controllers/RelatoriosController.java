package br.com.sigas.controllers;

import java.math.BigDecimal;
import java.time.LocalDate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import br.com.sigas.services.RelatoriosService;

@RestController
@RequestMapping("/relatorios")
public class RelatoriosController {

    @Autowired
    private RelatoriosService relatoriosService;

    @GetMapping("/operacoes/periodo")
    public ResponseEntity<?> getOperacoesPorPeriodo(
            @RequestParam("inicio") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate inicio,
            @RequestParam("fim") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fim) {
        try {
            return ResponseEntity.ok(relatoriosService.getOperacoesPorPeriodo(inicio, fim));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar relatório: " + e.getMessage());
        }
    }

    @GetMapping("/produtos/mais-vendidos")
    public ResponseEntity<?> getProdutosMaisVendidos(
            @RequestParam("inicio") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate inicio,
            @RequestParam("fim") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fim) {
        try {
            return ResponseEntity.ok(relatoriosService.getProdutosMaisVendidos(inicio, fim));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar relatório: " + e.getMessage());
        }
    }

    @GetMapping("/estoque-atual")
    public ResponseEntity<?> getEstoqueAtual() {
        try {
            return ResponseEntity.ok(relatoriosService.getEstoqueAtual());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar relatório: " + e.getMessage());
        }
    }

    @GetMapping("/resumo-financeiro")
    public ResponseEntity<?> getResumoFinanceiro(
            @RequestParam("inicio") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate inicio,
            @RequestParam("fim") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fim) {
        try {
            return ResponseEntity.ok(relatoriosService.getResumoFinanceiro(inicio, fim));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar relatório: " + e.getMessage());
        }
    }

    @GetMapping("/pessoas-juridicas")
    public ResponseEntity<?> getPessoasJuridicas() {
        try {
            return ResponseEntity.ok(relatoriosService.getPessoasJuridicas());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar relatório: " + e.getMessage());
        }
    }

    @GetMapping("/pessoas-fisicas")
    public ResponseEntity<?> getPessoasFisicas() {
        try {
            return ResponseEntity.ok(relatoriosService.getPessoasFisicas());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar relatório: " + e.getMessage());
        }
    }

    @GetMapping("/operacoes-detalhadas")
    public ResponseEntity<?> getOperacoesDetalhadas() {
        try {
            return ResponseEntity.ok(relatoriosService.getOperacoesDetalhadas());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar relatório: " + e.getMessage());
        }
    }

    @GetMapping("/estoque-baixo")
    public ResponseEntity<?> getEstoqueBaixo() {
        try {
            return ResponseEntity.ok(relatoriosService.getEstoqueBaixo());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar relatório: " + e.getMessage());
        }
    }

    @GetMapping("/total-vendas")
    public ResponseEntity<?> calcularTotalVendas() {
        try {
            BigDecimal totalVendas = relatoriosService.calcularTotalVendas();
            return ResponseEntity.ok(totalVendas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao calcular total de vendas: " + e.getMessage());
        }
    }

    // Endpoint para calcular total de compras
    @GetMapping("/total-compras")
    public ResponseEntity<?> calcularTotalCompras() {
        try {
            BigDecimal totalCompras = relatoriosService.calcularTotalCompras();
            return ResponseEntity.ok(totalCompras);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao calcular total de compras: " + e.getMessage());
        }
    }
}
